From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC] Revert "sierra_net: keep status interrupt URB active"
Date: Fri, 08 Nov 2013 21:44:14 +0100
Message-ID: <87txfm8vz5.fsf@nemi.mork.no>
References: <1383310428-19913-1-git-send-email-bjorn@mork.no>
	<1383596827.29469.1.camel@dcbw.foobar.com>
	<1383938944.29096.7.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	John Henderson <jhen@talk21.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52147 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757565Ab3KHUoV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 15:44:21 -0500
In-Reply-To: <1383938944.29096.7.camel@dcbw.foobar.com> (Dan Williams's
	message of "Fri, 08 Nov 2013 13:29:04 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams <dcbw@redhat.com> writes:
> On Mon, 2013-11-04 at 14:27 -0600, Dan Williams wrote:
>> On Fri, 2013-11-01 at 13:53 +0100, Bj=C3=B8rn Mork wrote:
>> > This reverts commit 7b0c5f21f348a66de495868b8df0284e8dfd6bbf.
>> >=20
>> > It's not easy to create a driver for all the various firmware
>> > bugs out there.
>> >=20
>> > This change caused regressions for a number of devices, which
>> > started to fail link detection and therefore became completely
>> > non-functional. The exact reason is yet unknown, it looks like
>> > the affected firmwares might actually need all or some of the
>> > additional SYNC messages the patch got rid of.
>> >=20
>> > Reverting is not optimal, as it will re-introduce the original
>> > problem, but it is currently the only alternative known to fix
>> > this issue.
>>=20
>> Instead, how does the following patch work for you?
>
> Bjorn, did you have a chance to try this patch out on your devices?

The only DirectIP device I have is the MC7710, which never had any of
the firmware issues you are trying to fix. I only tried to forward John=
s
issue.

When this patch worked for John, then I am pretty confident that you
have solved the problem here.



Thanks,
Bj=C3=B8rn
