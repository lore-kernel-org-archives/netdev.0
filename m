From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPSec: Policy dst bundles exhausting storage
Date: Tue, 10 Jun 2003 16:32:50 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.163250.70197099.davem@redhat.com>
References: <OF5BE4EDD9.7B1D7854-ON86256D41.007F1E5C-86256D41.008145BF@pok.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com
In-Reply-To: <OF5BE4EDD9.7B1D7854-ON86256D41.007F1E5C-86256D41.008145BF@pok.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Tom Lendacky" <toml@us.ibm.com>
   Date: Tue, 10 Jun 2003 18:32:00 -0500
   
   One other thing I did notice in both the v4 and v6 bundle create functions
   is the line x->u.rt.fl = *fl.  Shouldn't this be a memcpy?

Gcc emits a memcpy() check the assembly.  Structure assignment
is a perfectly legal to do this.
