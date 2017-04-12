From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/3] VSOCK: Add vsockmon device
Date: Wed, 12 Apr 2017 13:05:10 -0400 (EDT)
Message-ID: <20170412.130510.1661492983569723913.davem@davemloft.net>
References: <20170412160825.21037-1-stefanha@redhat.com>
        <20170412160825.21037-3-stefanha@redhat.com>
        <20170412193827-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefanha@redhat.com, netdev@vger.kernel.org, zyjzyj2000@gmail.com,
        ggarcia@abra.uab.cat, jhansen@vmware.com
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48080 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752557AbdDLRFO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 13:05:14 -0400
In-Reply-To: <20170412193827-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 12 Apr 2017 19:43:20 +0300

> On Wed, Apr 12, 2017 at 05:08:24PM +0100, Stefan Hajnoczi wrote:
>> +struct af_vsockmon_hdr {
>> +	__le64 src_cid;
>> +	__le64 dst_cid;
>> +	__le32 src_port;
>> +	__le32 dst_port;
>> +	__le16 op;			/* enum af_vsockmon_op */
>> +	__le16 transport;		/* enum af_vsockmon_transport */
>> +	__le16 len;			/* Transport header length */
>> +} __attribute__((packed));
> 
> I'd add a 2 byte padding here and then you do not need to pack it.

Indeed, use of the packed attribute is strongly discouraged.
