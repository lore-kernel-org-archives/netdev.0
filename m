From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPSec: Use of "sizeof" for header sizes, part II
Date: Tue, 01 Apr 2003 20:02:25 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030401.200225.88014087.davem@redhat.com>
References: <20030402.122518.62753078.yoshfuji@linux-ipv6.org>
	<20030401.193429.64279267.davem@redhat.com>
	<20030402.130232.78951283.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: toml@us.ibm.com, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030402.130232.78951283.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Wed, 02 Apr 2003 13:02:32 +0900 (JST)

   In article <20030401.193429.64279267.davem@redhat.com> (at Tue, 01 Apr 2003 19:34:29 -0800 (PST)), "David S. Miller" <davem@redhat.com> says:
   
   >    How about just removing 8 bytes from struct {ip,ipv6}_esp_hdr
   >    like this?
   >    
   > Sure, but does anyone need the 8 bytes there?  I thought so, which is
   > why I didn't think about your suggestion :-)
   
   Let's define
     #define IPV6_ESP_MINDATA  8
   
   and put "(sizeof(struct ip6_esp_hdr) + IPV6_ESP_MINDATA)" in such places.

I just checked, nobody cares about the 8 bytes in enc_data.

Therefore, I think you're idea of enc_data[0] is the best.

Someone please double check my claims and submit a patch. :-)
