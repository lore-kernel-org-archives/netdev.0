From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v3] linux: Report supported user features to the kernel
Date: Fri, 20 Dec 2013 10:20:21 -0800
Message-ID: <CAEP_g=9Asc30igbvSAdzUTEHFSDrGPrUizeNw1pegM6d62OZhA@mail.gmail.com>
References: <399ecc79d2539f4624d9b5363f37c8d358571fae.1387466318.git.tgraf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:46947 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751891Ab3LTSUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 13:20:42 -0500
Received: by mail-ie0-f170.google.com with SMTP id qd12so3547565ieb.15
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 10:20:41 -0800 (PST)
In-Reply-To: <399ecc79d2539f4624d9b5363f37c8d358571fae.1387466318.git.tgraf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 7:20 AM, Thomas Graf <tgraf@redhat.com> wrote:
> Following commit (''netlink: Do not enforce alignment of last Netlink
> attribute''), signal the ability to receive unaligned Netlink messages
> to the datapath to enable utilization of zerocopy optimizations.
>
> Opening a datapath is now done by issueing a OVS_DP_CMD_SET in order
> to overwrite previously set user features.
>
> Signed-off-by: Thomas Graf <tgraf@redhat.com>

Applied, thanks.
