From: "David S. Miller" <davem@redhat.com>
Subject: Re: e100-3.0.0_dev8 "Minneapolis Moline" release
Date: Wed, 18 Jun 2003 10:26:03 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030618.102603.48525259.davem@redhat.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107D977@orsmsx402.jf.intel.com>
	<slrnbf11i5.kck.lunz@stoli.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: lunz@falooley.org
In-Reply-To: <slrnbf11i5.kck.lunz@stoli.localnet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jason Lunz <lunz@falooley.org>
   Date: Wed, 18 Jun 2003 15:33:25 +0000 (UTC)

   Is the anonymous union in struct cb some kind of gcc3-only thing? It
   doesn't compile for my debian woody gcc 2.95 unless I name the union
   member.
   
Yes, please don't use anonymous unions in kernel code that
you expect to compile anything other than the most recent
versions of gcc.
