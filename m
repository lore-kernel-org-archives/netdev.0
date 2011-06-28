From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12] Fix various section mismatches and build errors.
Date: Mon, 27 Jun 2011 22:12:57 -0700 (PDT)
Message-ID: <20110627.221257.1290251511587162468.davem@davemloft.net>
References: <17dd5038b15d7135791aadbe80464a13c80758d3.1309182742.git.ralf@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, alan@linux.intel.com, bcasavan@sgi.com,
        airlied@linux.ie, grundler@parisc-linux.org,
        JBottomley@parallels.com, perex@perex.cz, rpurdie@rpsys.net,
        klassert@mathematik.tu-chemnitz.de, tj@kernel.org,
        dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org,
        linux-mips@linux-mips.org, linux-scsi@vger.kernel.org,
        linux-serial@vger.kernel.org, netdev@vger.kernel.org
To: ralf@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <17dd5038b15d7135791aadbe80464a13c80758d3.1309182742.git.ralf@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org


See commit:

commit 948252cb9e01d65a89ecadf67be5018351eee15e
Author: David S. Miller <davem@davemloft.net>
Date:   Tue May 31 19:27:48 2011 -0700

    Revert "net: fix section mismatches"
    
    This reverts commit e5cb966c0838e4da43a3b0751bdcac7fe719f7b4.
    
    It causes new build regressions with gcc-4.2 which is
    pretty common on non-x86 platforms.
    
    Reported-by: James Bottomley <James.Bottomley@HansenPartnership.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

and postings that led to this revert including:

http://marc.info/?l=linux-netdev&m=130653748205263&w=2
