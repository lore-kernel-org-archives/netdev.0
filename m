From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 00/13] NetLabel cleanups for 2.6.20 [GIT]
Date: Sat, 18 Nov 2006 22:19:39 -0500 (EST)
Message-ID: <XMMS.LNX.4.64.0611182218570.23112@d.namei>
References: <20061117223842.399078000@hp.com> <XMMS.LNX.4.64.0611172308070.13574@d.namei>
 <200611181110.25281.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="537530981-949499154-1163906379=:23112"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:47813 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1755749AbWKSDTl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Nov 2006 22:19:41 -0500
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <200611181110.25281.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--537530981-949499154-1163906379=:23112
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 18 Nov 2006, Paul Moore wrote:

> > There was one minor compilation issue caused by including linux/skbuff.h
> > in an SELinux header, which I fixed (see below).
> 
> <scratching head>
> Huh, sorry about that ... thanks for accepting the patches and making the fix.
> </scratching head>

Here's the error:

security/selinux/ss/policydb.c:472: error: conflicting types for 
â'class_destroy'
include/linux/device.h:295: error: previous declaration of 
â'class_destroy' was here


-- 
James Morris
<jmorris@namei.org>
--537530981-949499154-1163906379=:23112--
