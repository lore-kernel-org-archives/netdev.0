From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH] dccp: handle invalid feature options length
Date: Fri, 6 May 2011 21:57:33 +0200
Message-ID: <20110506195733.GA3527@gerrit.erg.abdn.ac.uk>
References: <1304688438.29544.16.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dccp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, security@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1304688438.29544.16.camel@dan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Dan Rosenberg:
| A length of zero (after subtracting two for the type and len fields) for
| the DCCPO_{CHANGE,CONFIRM}_{L,R} options will cause an underflow due to
| the subtraction.  The subsequent code may read past the end of the
| options value buffer when parsing.  I'm unsure of what the consequences
| of this might be, but it's probably not good.
| 
Please disregard my earlier message, I erred.
Dan is right, his patch is correct and definitively valid.
A length of 0 would be cast to 0xff and then cause buffer overrun.

| Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
| Cc: stable@kernel.org
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
