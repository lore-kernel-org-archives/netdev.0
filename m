From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix esp6 extension headers handling
Date: Sat, 07 Jun 2003 02:22:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030607.022241.98862720.davem@redhat.com>
References: <3EDF3EB4.8010105@tml.hut.fi>
	<873cioqxch.wl@karaba.org>
	<87wufzxe8p.wl@karaba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mk@linux-ipv6.org
In-Reply-To: <87wufzxe8p.wl@karaba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Mitsuru KANDA / 神田 充 <mk@linux-ipv6.org>
   Date: Sat, 07 Jun 2003 03:17:10 +0900

   The attached diff fixes esp6 extension headers handling bug 
   which reported by Henrik.
   
   I introduced ip6_find_1stfragopt() instead of get_offset().
   
   # ip6_found_nexthdr() is just renamed ip6_find_1stfragopt()
   # in order to represent collect functionality.

Patch applied, thank you.
