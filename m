From: "David S. Miller" <davem@redhat.com>
Subject: Re: e1000 performance hack for ppc64 (Power4)
Date: Fri, 13 Jun 2003 22:36:34 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030613.223634.74746570.davem@redhat.com>
References: <20030613223841.GB32097@krispykreme>
	<20030613.154634.74748085.davem@redhat.com>
	<3EEAAFA6.9080609@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, haveblue@us.ibm.com, hdierks@us.ibm.com,
   scott.feldman@intel.com, dwg@au1.ibm.com, linux-kernel@vger.kernel.org,
   milliner@us.ibm.com, ricardoz@us.ibm.com, twichell@us.ibm.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
In-Reply-To: <3EEAAFA6.9080609@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Nivedita Singhvi <niv@us.ibm.com>
   Date: Fri, 13 Jun 2003 22:16:22 -0700

   Yep, but it really doesn't have too many options (sic pun ;))..
   i.e. The max the options can add are 40 bytes, speaking
   strictly TCP, not IP. This really should fit into one extra
   cacheline for most architectures, at most, right?
   
It's what the bottom of the header is aligned to, but
we build the packet top to bottom not the other way around.
