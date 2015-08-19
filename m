From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 01/13] ip_tunnels: remove custom alignment
 and packing
Date: Wed, 19 Aug 2015 18:20:09 +0200
Message-ID: <20150819162009.GA3635@pox.localdomain>
References: <cover.1439978875.git.jbenc@redhat.com>
 <47163461d8b7ef0fa60ea3fd31d0cc0e60303913.1439978875.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:38179 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbbHSQUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 12:20:12 -0400
Received: by wicja10 with SMTP id ja10so13041916wic.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 09:20:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47163461d8b7ef0fa60ea3fd31d0cc0e60303913.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/15 at 12:09pm, Jiri Benc wrote:
> The custom alignment of struct ip_tunnel_key is unnecessary. In struct
> sw_flow_key, it starts at offset 256, in struct ip_tunnel_info it's the
> first field.
> 
> The structure is also packed even without the __packed keyword.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

I came to the same conclusion but didn't want to change it in the original
series.

Acked-by: Thomas Graf <tgraf@suug.ch>
