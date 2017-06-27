From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH/RFC net-next 2/9] nfp: add phys_switch_id support
Date: Tue, 27 Jun 2017 16:33:13 -0700
Message-ID: <20170627163313.24f5b2ab@cakuba.netronome.com>
References: <1498605709-22574-1-git-send-email-simon.horman@netronome.com>
        <1498605709-22574-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:33468 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753939AbdF0XhC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 19:37:02 -0400
Received: by mail-pg0-f45.google.com with SMTP id f127so22740938pgc.0
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 16:37:01 -0700 (PDT)
In-Reply-To: <1498605709-22574-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jun 2017 01:21:42 +0200, Simon Horman wrote:
> Add phys_switch_id support by allowing lookup of
> SWITCHDEV_ATTR_ID_PORT_PARENT_ID via the nfp_repr_port_attr_get
> switchdev operation.
> 
> This is visible to user-space in the phys_switch_id attribute
> of a netdev.
> 
> e.g.
> cd /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0
> find . -name phys_switch_id | xargs grep .
> ./net/eth3/phys_switch_id:00154d1300bd
> ./net/eth4/phys_switch_id:00154d1300bd
> ./net/eth2/phys_switch_id:00154d1300bd
> grep: ./net/eth5/phys_switch_id: Operation not supported
> 
> In the above eth2 and eth3 and representor netdevs for the first and second
> physical port. eth4 is the representor for the PF. And eth5 is the PF netdev.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
