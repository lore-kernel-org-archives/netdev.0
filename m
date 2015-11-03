From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH] Confirm success for each tc -batch command
Date: Tue, 3 Nov 2015 12:46:21 -0800
Message-ID: <20151103124621.06e37725@xeon-e3>
References: <1446120596-10399-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	Petr =?UTF-8?B?UMOtc2HFmQ==?= <ppisar@redhat.com>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48341 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932526AbbKCUqR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 15:46:17 -0500
In-Reply-To: <1446120596-10399-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Oct 2015 13:09:56 +0100
Phil Sutter <phil@nwl.cc> wrote:

> If `tc -force -batch' is fed by a controlling program from a pipe,
> it's not possible to recognize when a command has been processes
> successfully.
>=20
> This patch adds an optional `-OK' option to the tc(8) tool, so `tc
> -force -OK -batch' will print "OK\n" to standard output on each
> successfully completed tc command.
>=20
> Signed-off-by: Petr P=C3=ADsa=C5=99 <ppisar@redhat.com>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Why use batch mode if you are feeding it from a pipe?
This seems like unnecessary feature creep.
