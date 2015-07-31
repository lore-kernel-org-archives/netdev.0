From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf: add helpers to access tunnel metadata
Date: Fri, 31 Jul 2015 08:43:27 -0700
Message-ID: <55BB979F.5010606@plumgrid.com>
References: <1438295817-27295-1-git-send-email-ast@plumgrid.com>
 <20150731081410.GD4738@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34968 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753989AbbGaPn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 11:43:28 -0400
Received: by pabkd10 with SMTP id kd10so42821613pab.2
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 08:43:27 -0700 (PDT)
In-Reply-To: <20150731081410.GD4738@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/31/15 1:14 AM, Thomas Graf wrote:
> On 07/30/15 at 03:36pm, Alexei Starovoitov wrote:
>> +	to->tunnel_id = be64_to_cpu(info->key.tun_id);
>> +	to->remote_ipv4 = be32_to_cpu(info->key.ipv4_src);
>
> BTW: I have a patch ready to avoid this as you suggested which I'll
> post as soon as GRE and Geneve are done as well. It would require a
> lot of special handling until all encaps have been converted.

great. looking forward.
