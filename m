From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BKPATCH] Re: [PATCH][2.5.22] OOPS in tcp_v6_get_port
Date: Mon, 17 Jun 2002 21:17:21 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020617.211721.123286561.davem@redhat.com>
References: <20020618024934.GA4274@conectiva.com.br>
	<20020618035804.GA18759@conectiva.com.br>
	<20020618041539.GB18759@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: critson@perlfu.co.uk, torvalds@transmeta.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20020618041539.GB18759@conectiva.com.br>
List-Id: netdev.vger.kernel.org

   From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
   Date: Tue, 18 Jun 2002 01:15:39 -0300
   
   Oops, brain fart, David, please don't apply, in tcp_create_openreq_child
   we overwrite the ->pinet6 field after the constructor inits it to the proper
   value :( Please leave the old patch in place for a while... :(

No problem.
