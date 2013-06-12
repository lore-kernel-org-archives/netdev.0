From: Dean Nelson <dnelson@redhat.com>
Subject: Re: [PATCH net-next] e1000e: restore call to pci_clear_master()
Date: Wed, 12 Jun 2013 14:45:56 -0500
Message-ID: <51B8CFF4.80709@redhat.com>
References: <20130612174747.7449.40767.email-sent-by-dnelson@teal>  <51B8C035.9010105@cogentembedded.com> <51B8C393.3090100@redhat.com> <1371066071.2133.40.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>,
	Konstantin Khlebnikov <khlebnikov@openvz.org>,
	netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54344 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754947Ab3FLTqA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 15:46:00 -0400
In-Reply-To: <1371066071.2133.40.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2013 02:41 PM, Jeff Kirsher wrote:
> On Wed, 2013-06-12 at 13:53 -0500, Dean Nelson wrote:
>> On 06/12/2013 01:38 PM, Sergei Shtylyov wrote:
>>> Hello.
>>>
>>> On 06/12/2013 09:47 PM, Dean Nelson wrote:
>>>
>>>> In attempting to resolve a minor merge conflict, commit
>>>> e5f2ef7ab4690d2e8faa
>>>> accidently dropped a call to pci_clear_master() that was intended to
>>>> remain
>>>> in place.
>>>
>>>> Commit 4e0855dff094b0d56d6b replaced a call to pci_disable_device() by
>>>> one to
>>>
>>>      Please specify the summary line in parens for both commmits you're
>>> mentioning.
>>
>> Sorry, I'm not understanding fully. Are you asking me to repost the
>> patch with the changelog modified, such that each of the commits
>> mentioned has their summary statement following, enclosed in parens?
>>
>>
>>>> pci_clear_master(). And then commit 66148babe728f3e00e13 deleted a
>>>> number of
>>>> lines starting two lines following that call.
>>>
>>>> This patch restores the call to pci_clear_master() in __e1000_shutdown().
>>>
>>>> Signed-off-by: Dean Nelson <dnelson@redhat.com>
>>>
>>> WBR, Sergei
>>>
>>>
>>
>> Also, I mistyped Jeff Kirsher's email address. It's corrected above.
>> (Sorry, Jeff.)
>
> No problem, will you be sending a v2 based on Sergei's feedback?  Just
> need to know if I add this patch to my queue or wait for v2.

Yes, I just sent it.


>
