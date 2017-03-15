From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 01/13] i40evf: fix client warnings
Date: Tue, 14 Mar 2017 17:39:49 -0700 (PDT)
Message-ID: <20170314.173949.1164218813681950110.davem@davemloft.net>
References: <20170314223308.53451-1-jeffrey.t.kirsher@intel.com>
        <20170314223308.53451-2-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: faisal.latif@intel.com, netdev@vger.kernel.org, nhorman@redhat.com,
        sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58546 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750849AbdCOAjv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 20:39:51 -0400
In-Reply-To: <20170314223308.53451-2-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 14 Mar 2017 15:32:56 -0700

> From: Faisal Latif <faisal.latif@intel.com>
> 
> The function prototype in i40evf_client.h are giving warnings while
> compiling i40iwvf module. Move these function prototypes to i40evf.h.
> Also fix return code from u32 to int and this return code is
> consistent with i40e_client.h
> 
> Change-Id: Ie3757f844993aabc27654aaf02ec14fb985ad2c4
> Signed-off-by: Faisal Latif <faisal.latif@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

There is no such i40evf_client.h header file in the tree.

>  int i40evf_config_rss(struct i40evf_adapter *adapter);
> +int i40evf_lan_add_device(struct i40evf_adapter *adapter);
> +int i40evf_lan_del_device(struct i40evf_adapter *adapter);
> +void i40evf_client_subtask(struct i40evf_adapter *adapter);
> +void i40evf_notify_client_message(struct i40e_vsi *vsi, u8 *msg, u16 len);
> +void i40evf_notify_client_l2_params(struct i40e_vsi *vsi);
> +void i40evf_notify_client_open(struct i40e_vsi *vsi);
> +void i40evf_notify_client_close(struct i40e_vsi *vsi);
>  #endif /* _I40EVF_H_ */

And these functions do not exist in the tree either.

This really isn't acceptable.
