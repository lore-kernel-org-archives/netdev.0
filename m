From: cranium 2003 <cranium.2003@gmail.com>
Subject: who calls eth_header_cache_update
Date: Mon, 31 Jan 2005 17:57:01 +0530
Message-ID: <1d55641b0501310427451b11@mail.gmail.com>
Reply-To: cranium 2003 <cranium.2003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.linux.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
           Who need to call following function in linux kernel?
void eth_header_cache_update(struct hh_cache *hh, struct net_device
*dev, unsigned char * haddr)
{
        memcpy(((u8*)hh->hh_data) + HH_DATA_OFF(sizeof(struct ethhdr)),
               haddr, dev->addr_len);
}

regards,
cranium
