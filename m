From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: fix data offset calculation when pushing frag
 options {dst1opts|auth}
Date: Thu, 10 Jul 2003 17:22:32 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030710.172232.02275886.davem@redhat.com>
References: <20030710234449.GB30577@rei.rakuen>
	<20030711.091814.128467921.yoshfuji@linux-ipv6.org>
	<20030711002713.GC30577@rei.rakuen>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, jmorris@intercode.com.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20030711002713.GC30577@rei.rakuen>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Thomas Graf <tgraf@suug.ch>
   Date: Fri, 11 Jul 2003 02:27:13 +0200

   * yoshfuji@linux-ipv6.org wrote:
   > +		exthdrlen += rt->u.dst.header_len + (opt ? opt->opt_flen : 0);
   
   exthdrlen is uninitialized.
   
Yoshfuji already fixed this, see his followup.
