From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 03/16] net/mlx5: E-Switch, Add miss rule for
 offloads mode
Date: Mon, 27 Jun 2016 23:40:07 +0300
Message-ID: <CAJ3xEMhuZeRakGubqiZzQRwdhRYLgLzQwOCS6MdxBOujViKXJA@mail.gmail.com>
References: <1467043649-28594-1-git-send-email-saeedm@mellanox.com>
 <1467043649-28594-4-git-send-email-saeedm@mellanox.com> <8d994e8f-f4bf-f6b3-c47b-c4c4a94da647@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:33108 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbcF0UkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 16:40:08 -0400
Received: by mail-oi0-f44.google.com with SMTP id u201so216874017oie.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 13:40:08 -0700 (PDT)
In-Reply-To: <8d994e8f-f4bf-f6b3-c47b-c4c4a94da647@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 7:53 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:

>> +static int esw_add_fdb_miss_rule(struct mlx5_eswitch *esw)
>> +{
>> +       struct mlx5_flow_destination dest;
>> +       struct mlx5_flow_rule *flow_rule = NULL;
>> +       int match_header = 0;
>
>
>    This variable doesn't appear necessary...

yep

>> +       dest.type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
>> +       dest.vport_num = 0;
>> +
>> +       flow_rule = mlx5_add_flow_rule(esw->fdb_table.fdb, match_header,
>> match_c,
>
>
>    Why not just pass 0 instead of 'match_header'?

Correct, will fix that.
