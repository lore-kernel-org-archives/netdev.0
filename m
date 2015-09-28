From: roopa <roopa@cumulusnetworks.com>
Subject: Re: Per-flow IPv4 ECMP
Date: Mon, 28 Sep 2015 06:48:09 -0700
Message-ID: <56094519.8030801@cumulusnetworks.com>
References: <BN1PR0201MB05777291EE3D91068CB2EE8E944F0@BN1PR0201MB0577.namprd02.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, pch@ordbogen.com
To: Matthew Dupre <Matthew.Dupre@metaswitch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36483 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755163AbbI1NsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 09:48:11 -0400
Received: by pablk4 with SMTP id lk4so78429522pab.3
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 06:48:10 -0700 (PDT)
In-Reply-To: <BN1PR0201MB05777291EE3D91068CB2EE8E944F0@BN1PR0201MB0577.namprd02.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/28/15, 1:57 AM, Matthew Dupre wrote:
> Hi,
>
> I'm interested in the Linux kernel's support for per-flow IPv4 ECMP (=
i.e. consistent path selection based on a hash of the connection tuple)=
=2E  I'd been led to believe[1] that this depended on the route cache, =
which was removed in 3.6.
>
> However, I tested a route with multiple next hops on a 3.10 and 3.13 =
kernel, and ECMP was per-flow!  Obviously I'm pleased that this was the=
 case, but I'd like to understand why this is supported, and whether I =
can rely on it in future.
>
> Could anyone give me a little clarification on whether this is now su=
pported by some means other than the route cache, and whether that supp=
ort is intended to be continued?
>
This is being worked on currently by Peter N=F8rlund
https://lwn.net/Articles/657431/
