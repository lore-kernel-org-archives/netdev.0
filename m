From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] libbpf: support more map options
Date: Tue, 03 Oct 2017 21:26:45 -0700 (PDT)
Message-ID: <20171003.212645.898173960092356152.davem@davemloft.net>
References: <20171002164129.47986-1-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, brouer@redhat.com,
        chonggangli@google.com, netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32812 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751047AbdJDE0q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 00:26:46 -0400
In-Reply-To: <20171002164129.47986-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Mon,  2 Oct 2017 12:41:27 -0400

> From: Craig Gallek <kraig@google.com>
> 
> The functional change to this series is the ability to use flags when
> creating maps from object files loaded by libbpf.  In order to do this,
> the first patch updates the library to handle map definitions that
> differ in size from libbpf's struct bpf_map_def.
> 
> For object files with a larger map definition, libbpf will continue to load
> if the unknown fields are all zero, otherwise the map is rejected.  If the
> map definition in the object file is smaller than expected, libbpf will use
> zero as a default value in the missing fields.

Judging by the feedback I anticipate another spin of this series.
