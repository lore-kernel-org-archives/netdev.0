From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Tons of "BUG: dst overflow ..." messages
Date: Wed, 29 Sep 2004 00:57:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415A40D0.7040403@pobox.com>
References: <415A3635.4070000@pobox.com> <20040928214055.609f7715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040928214055.609f7715.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Wed, 29 Sep 2004 00:12:37 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
>>BUG: dst underflow 0: cf5dd180 at f8c0be5d
>>BUG: dst underflow 0: cf5dd180 at f8c0d15c
>>BUG: dst underflow 0: cf5dd180 at f8c1656f
> 
> 
> Can you match up the 0xf8xxxxxx addresses to spots
> in your System.map?  Thanks.


All my addresses in System.map start with 0xc0xxxxxx.

But /proc/modules OTOH...

nfsd 212256 9 - Live 0xf8c96000
exportfs 5248 1 nfsd, Live 0xf8bcb000
e1000 80132 0 - Live 0xf8be3000
8139too 21504 0 - Live 0xf8bc4000
crc32 4480 1 8139too, Live 0xf8b68000
ipv6 232192 38 - Live 0xf8c01000
		       ^^^^  appears to be this
ip_nat_irc 4080 0 - Live 0xf8839000
ip_conntrack_irc 70960 1 ip_nat_irc, Live 0xf8ba9000
ip_nat_ftp 4592 0 - Live 0xf8b47000
ip_conntrack_ftp 71856 1 ip_nat_ftp, Live 0xf8b96000
ipt_MASQUERADE 3584 1 - Live 0xf8b66000
iptable_nat 20644 4 ip_nat_irc,ip_nat_ftp,ipt_MASQUERADE, Live 0xf8b6e000
iptable_mangle 2688 0 - Live 0xf8830000
ipt_LOG 6656 1 - Live 0xf8b41000
ipt_limit 2432 1 - Live 0xf883d000
ipt_state 2048 3 - Live 0xf883b000
ip_conntrack 38200 7 
ip_nat_irc,ip_conntrack_irc,ip_nat_ftp,ip_conntrack_ftp,ipt_MASQUERADE,iptable_nat,ipt_state, 
Live 0xf8b4a000
iptable_filter 2688 1 - Live 0xf8810000
ip_tables 16256 7 
ipt_MASQUERADE,iptable_nat,iptable_mangle,ipt_LOG,ipt_limit,ipt_state,iptable_filter, 
Live 0xf8827000
dm_mod 48896 0 - Live 0xf8840000
battery 10252 0 - Live 0xf882c000
raid1 13824 2 - Live 0xf8815000
ata_piix 7044 5 - Live 0xf8824000
sata_promise 7556 2 - Live 0xf8812000
libata 36612 2 ata_piix,sata_promise, Live 0xf881a000
