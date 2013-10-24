From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [Xen-devel] [PATCH net] xen-netback: add the scenario which now beyond the range time_after_eq().
Date: Thu, 24 Oct 2013 11:04:45 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73A7@saturn3.aculab.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com> <525FBB4F02000078000FBB30@nat28.tlf.novell.com> <525FA79F.8060601@oracle.com> <525FC98002000078000FBBB5@nat28.tlf.novell.com> <52601274.5010008@oracle.com> <526102DE02000078000FBFBB@nat28.tlf.novell.com> <5260EDD8.4020608@oracle.com> <52610CD202000078000FC00B@nat28.tlf.novell.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7396@saturn3.aculab.com> <20131018112417.GA20185@zion.uk.xensource.com> <52678286.6000802@oracle.com> <5268025002000078000A56B5@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>, <annie.li@oracle.com>,
	<netdev@vger.kernel.org>
To: "Jan Beulich" <jbeulich@suse.com>, <wei.liu2@citrix.com>,
	<jianhai.luan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54347 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754101Ab3JXKG3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 06:06:29 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16864-08 for <netdev@vger.kernel.org>;
 Thu, 24 Oct 2013 11:06:26 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <5268025002000078000A56B5@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> As I understand it, this is the idea of this patch -- to narrow down the
> >> timing window.
> >Jan,  do you agree the idea or have better suggestion to me.
> 
> As said before - I disagree (reducing a timing window is never a solution,
> only eliminating it is), and I pointed at the alternative (using 64-bit
> calculations) before.

If the error is reduced to a few seconds in 48 days (at 1kHz HZ) and the
system has to be idle for the 48 days I wouldn't be too worried.
Especially if this is 'time based credit' and the effect is just that
of the link (or whatever) being busy rather than idle.

	David
