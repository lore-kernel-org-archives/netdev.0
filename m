From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [Xen-devel] [PATCH net] xen-netback: add the scenario which now beyond the range time_after_eq().
Date: Fri, 18 Oct 2013 09:40:33 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7396@saturn3.aculab.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com> <525FBB4F02000078000FBB30@nat28.tlf.novell.com> <525FA79F.8060601@oracle.com> <525FC98002000078000FBBB5@nat28.tlf.novell.com> <52601274.5010008@oracle.com> <526102DE02000078000FBFBB@nat28.tlf.novell.com> <5260EDD8.4020608@oracle.com> <52610CD202000078000FC00B@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	"jianhai luan" <jianhai.luan@oracle.com>, <netdev@vger.kernel.org>
To: "Jan Beulich" <JBeulich@suse.com>, "annie li" <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55411 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752339Ab3JRIms convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 04:42:48 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01764-10 for <netdev@vger.kernel.org>;
 Fri, 18 Oct 2013 09:42:46 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <52610CD202000078000FC00B@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > My understanding is this patch does not simply double the span, it is
> > just stricter than the original one. Please check my previous comments,
> > I paste it here.
> 
> No, the code (on a 32-bit arch) just _can't_ handle jiffies differences
> beyond 2^32, no matter how cleverly you use the respective macros.
> All arithmetic there is done modulo 2^32.

I haven't followed this discussion very closely but it might be possible
to arrange that the 'incorrect lack of credit' only occurs for a few
seconds every time 'jiffies' wraps - instead of half of the time.
Then you'd have to be extremely unlucky to hit the timing window.

	David
