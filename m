From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 09 Jun 2003 10:19:59 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609.101959.62355600.davem@redhat.com>
References: <20030522.153330.74735095.davem@redhat.com>
	<20030529205125.GA30058@netnation.com>
	<16091.11735.721251.925522@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert.Olsson@data.slu.se
In-Reply-To: <16091.11735.721251.925522@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Robert Olsson <Robert.Olsson@data.slu.se>
   Date: Mon, 2 Jun 2003 12:58:31 +0200
   
    And later GC have to remove all enties with spin_lock_bh hold (no
    packet processing runs). I see packet drops exactly when GC
    runs. Tuning GC might help but it's something to observe.

Please note, in 2.5.x, holding of this lock on one cpu does
not prevent packet processing (even for routes on same hash
chain) on another cpu because we use RCU there.
