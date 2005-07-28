From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: [PATCH] emac: add bamboo support
Date: Thu, 28 Jul 2005 10:31:09 -0700
Message-ID: <20050728173109.GB16041@gate.ebshome.net>
References: <20050727104247.C1114@cox.net> <20050728065943.GA16041@gate.ebshome.net> <1122571506.22059.146.camel@rhino.az.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Porter <mporter@kernel.crashing.org>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wade Farnsworth <wfarnsworth@mvista.com>
Content-Disposition: inline
In-Reply-To: <1122571506.22059.146.camel@rhino.az.mvista.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 28, 2005 at 10:25:07AM -0700, Wade Farnsworth wrote:
> If you know of a better way of doing this please let me know.

Yes, I do and IIRC told you last time. Make it generic - move all 
board specific stuff where it belongs - board support files. Add 
additional field(s) to ocp_func_emac_data which will allow EMAC driver 
to override PHY modes, the same way we specify PHY id now, for 
example.

With this approach, we won't have to add another board specific crap 
to the driver next time hw vendor fuck ups their hw.

-- 
Eugene
