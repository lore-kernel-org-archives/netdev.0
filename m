From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Don't insert empty
 OVS_VPORT_ATTR_OPTIONS attribute
Date: Tue, 2 Apr 2013 16:36:54 -0700
Message-ID: <CAEP_g=9t4RDa9JwxhkLKq3DCjqFzyK6d+sGVu5YE2Wic-q1LRw@mail.gmail.com>
References: <8f6704668f7f795658b48a7b0219c88d0ca088a3.1364941760.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:52200 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755073Ab3DBXhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 19:37:15 -0400
Received: by mail-oa0-f71.google.com with SMTP id o6so5210141oag.6
        for <netdev@vger.kernel.org>; Tue, 02 Apr 2013 16:37:14 -0700 (PDT)
In-Reply-To: <8f6704668f7f795658b48a7b0219c88d0ca088a3.1364941760.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 2, 2013 at 3:30 PM, Thomas Graf <tgraf@suug.ch> wrote:
> The port specific options are currently unused resulting in an
> empty OVS_VPORT_ATTR_OPTIONS nested attribute being inserted
> into every OVS_VPORT_CMD_GET message.
>
> Don't insert OVS_VPORT_ATTR_OPTIONS if no options are present.
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
