From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH 2/2] vhost_net: a kernel-level virtio server
Date: Wed, 12 Aug 2009 14:27:31 -0500
Message-ID: <4A8317A3.4030303@codemonkey.ws>
References: <cover.1249930169.git.mst@redhat.com> <200908121903.22325.arnd@arndb.de> <20090812172141.GA29966@redhat.com> <200908121959.47222.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org,
	"Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f196.google.com ([209.85.221.196]:45062 "EHLO
	mail-qy0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471AbZHLT1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 15:27:39 -0400
In-Reply-To: <200908121959.47222.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann wrote:
>> As I pointed out earlier, most code in virtio net is asymmetrical: guest
>> provides buffers, host consumes them.  Possibly, one could use virtio
>> rings in a symmetrical way, but support of existing guest virtio net
>> means there's almost no shared code.
>>     
>
> The trick is to swap the virtqueues instead. virtio-net is actually
> mostly symmetric in just the same way that the physical wires on a
> twisted pair ethernet are symmetric (I like how that analogy fits).
>   

It's already been done between two guests.  See 
http://article.gmane.org/gmane.linux.kernel.virtualization/5423

Regards,

Anthony Liguori
