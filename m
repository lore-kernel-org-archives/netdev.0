From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] libbpf: support more map options
Date: Thu, 05 Oct 2017 21:42:47 -0700 (PDT)
Message-ID: <20171005.214247.356487327869316808.davem@davemloft.net>
References: <20171005144158.14860-1-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, brouer@redhat.com,
        chonggangli@google.com, netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57584 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751511AbdJFEmy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 00:42:54 -0400
In-Reply-To: <20171005144158.14860-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Thu,  5 Oct 2017 10:41:56 -0400

> The functional change to this series is the ability to use flags when
> creating maps from object files loaded by libbpf.  In order to do this,
> the first patch updates the library to handle map definitions that
> differ in size from libbpf's struct bpf_map_def.
> 
> For object files with a larger map definition, libbpf will continue to load
> if the unknown fields are all zero, otherwise the map is rejected.  If the
> map definition in the object file is smaller than expected, libbpf will use
> zero as a default value in the missing fields.

Series applied, thanks.
