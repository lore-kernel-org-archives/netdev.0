From: "David S. Miller" <davem@redhat.com>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Wed, 10 Dec 2003 16:09:46 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210160946.4110c611.davem@redhat.com>
References: <20031210152039.055e887a.davem@redhat.com>
	<Pine.LNX.4.44.0312110135440.1519-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, ak@suse.de, ruddk@us.ibm.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, chester.f.johnson@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0312110135440.1519-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 11 Dec 2003 02:06:09 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> But the common average chain length for full table is 16 and the
> different TOS values are usually 1 or 2 per path. We do not talk
> about intentional DoS.

Your system has not configured it's rthash table size properly, see
recent discussions Robert has been making here.  You should have
rthash sized somewhere near the number of entries a full system
will have.

But regardless, let us say that your system has complexity O(16)
lookups as you mention, your proposal changes this to O(16+8).
