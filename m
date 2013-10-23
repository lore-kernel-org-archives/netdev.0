From: "Jan Beulich" <jbeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: add the scenario
 which now beyond the range time_after_eq().
Date: Wed, 23 Oct 2013 17:07:28 +0100
Message-ID: <5268025002000078000A56B5@nat28.tlf.novell.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com>
 <525FBB4F02000078000FBB30@nat28.tlf.novell.com>
 <525FA79F.8060601@oracle.com>
 <525FC98002000078000FBBB5@nat28.tlf.novell.com>
 <52601274.5010008@oracle.com>
 <526102DE02000078000FBFBB@nat28.tlf.novell.com>
 <5260EDD8.4020608@oracle.com>
 <52610CD202000078000FC00B@nat28.tlf.novell.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7396@saturn3.aculab.com>
 <20131018112417.GA20185@zion.uk.xensource.com>
 <52678286.6000802@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>, <annie.li@oracle.com>,
	<netdev@vger.kernel.org>
To: <David.Laight@ACULAB.COM>, <wei.liu2@citrix.com>,
	<jianhai.luan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:49408 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034Ab3JWQHc convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:5:1>);
	Wed, 23 Oct 2013 12:07:32 -0400
In-Reply-To: <52678286.6000802@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> jianhai luan <jianhai.luan@oracle.com> 10/23/13 10:02 AM >>>
>On 2013-10-18 19:24, Wei Liu wrote:
>> On Fri, Oct 18, 2013 at 09:40:33AM +0100, David Laight wrote:
>>>>> My understanding is this patch does not simply double the span, it is
>>>>> just stricter than the original one. Please check my previous comments,
>>>>> I paste it here.
>>>> No, the code (on a 32-bit arch) just _can't_ handle jiffies differences
>>>> beyond 2^32, no matter how cleverly you use the respective macros.
>>>> All arithmetic there is done modulo 2^32.
>>> I haven't followed this discussion very closely but it might be possible
>>> to arrange that the 'incorrect lack of credit' only occurs for a few
>>> seconds every time 'jiffies' wraps - instead of half of the time.
>>> Then you'd have to be extremely unlucky to hit the timing window.
>>>
>> As I understand it, this is the idea of this patch -- to narrow down the
>> timing window.
>Jan,  do you agree the idea or have better suggestion to me.

As said before - I disagree (reducing a timing window is never a solution,
only eliminating it is), and I pointed at the alternative (using 64-bit
calculations) before.

Jan
