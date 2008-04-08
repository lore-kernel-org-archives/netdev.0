From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: A Linux TCP SACK Question
Date: Tue, 8 Apr 2008 07:07:51 -0700
Message-ID: <1e41a3230804080707t2e3ece4p3786eceaa8ea6d64@mail.gmail.com>
References: <fc471cb97cfd.47f5520e@fnal.gov>
	 <000b01c89699$00e99590$c95ee183@D2GT6T71>
	 <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
	 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
	 <000f01c896a1$3022fec0$c95ee183@D2GT6T71>
	 <649aecc70804051417l4cf9b30asec8ca8d55e79e051@mail.gmail.com>
	 <fb8e9e4f102e.47f8ebfd@fnal.gov>
	 <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
	 <000701c898bf$99fc3f80$c95ee183@D2GT6T71>
	 <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Wenji Wu" <wenji@fnal.gov>, "Sangtae Ha" <sangtae.ha@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.179]:58070 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbYDHOHx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 10:07:53 -0400
Received: by el-out-1112.google.com with SMTP id v27so1446335ele.17
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2008 07:07:53 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 7, 2008 at 11:36 PM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
>
> On Mon, 7 Apr 2008, Wenji Wu wrote:
>
>  > >I don't think reorderings frequently happened in your directly
>  > >connected networking scenario. Please post your tcpdump file for
>  > >clearing out all doubts.
>  >
>  > https://plone3.fnal.gov/P0/WAN/Members/wenji/tcp_dump_files_sack/
>  >
>  > Two tcpdump files: one with SACK on, the other with SACK off. The =
test
>  > configures described in my previous emails.
>
>  NewReno never retransmitted anything in them (except at the very end=
 of
>  the transfer). Probably something related to how tp->reordering beha=
ves
>  I suppose...

Yes, this looks very suspicious.  Can we see this again with TSO off?

  -John
