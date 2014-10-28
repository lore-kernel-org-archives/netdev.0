From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] ovs: Turn vports with dependencies into separate modules
Date: Tue, 28 Oct 2014 14:42:19 -0700
Message-ID: <CAADnVQK2HRn=XyqF==tuDPFgA5gamVCZmxg5ELVjBX2i0dYwfA@mail.gmail.com>
References: <ab9438abe3e23289db6f850eea9626fe8bd0a969.1413991519.git.tgraf@suug.ch>
	<20141028.144344.398016097830457432.davem@davemloft.net>
	<CAADnVQ+Z6-7sdWAEvHkKR==Nds6hqBfbfPmtUDiZXOTE9DRnGw@mail.gmail.com>
	<20141028.172743.459865270069950735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:33251 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755914AbaJ1VmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 17:42:20 -0400
Received: by mail-qg0-f54.google.com with SMTP id q108so1277879qgd.41
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 14:42:19 -0700 (PDT)
In-Reply-To: <20141028.172743.459865270069950735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2014 at 2:27 PM, David Miller <davem@davemloft.net> wrote:
>>
>> it fails the build when lockdep is on:
>> ERROR: "lockdep_ovsl_is_held" [net/openvswitch/vport-gre.ko] undefined!
>
> I've fixed it thusly:

thanks! that was quick. the fix looks good.
