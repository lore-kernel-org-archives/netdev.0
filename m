From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH 2.6.9-rc2 4/8] S2io: hardware fixes
Date: Sat, 09 Oct 2004 20:24:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4168AB78.50704@osdl.org>
References: <004301c4ad97$be6a7010$9810100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Francois Romieu'" <romieu@fr.zoreil.com>, netdev@oss.sgi.com,
        leonid.grossman@s2io.com, raghavendra.koushik@s2io.com,
        rapuru.sriram@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@s2io.com
In-Reply-To: <004301c4ad97$be6a7010$9810100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ravinandan Arakali wrote:
> Jeff,
> Sorry about that. We'll add the signed-off-by line.
> We are sending the patches as and when they are completed.
> In the next couple of days, the remaining patches should
> be done. Do you want us to send them after all are complete
> or is it okay to send each patch as and when completed ?
> 
> Thanks,
> Ravi
> 
> -----Original Message-----
> From: Jeff Garzik [mailto:jgarzik@pobox.com]
> Sent: Friday, October 08, 2004 5:11 PM
> To: ravinandan.arakali@s2io.com
> Cc: 'Francois Romieu'; netdev@oss.sgi.com; leonid.grossman@s2io.com;
> raghavendra.koushik@s2io.com; rapuru.sriram@s2io.com
> Subject: Re: [PATCH 2.6.9-rc2 4/8] S2io: hardware fixes
> 
> 
> 48 hours passed between patch #3 and patch #4.  Is there a problem with 
> your email system?
> 
> Also, your patches do not include the "signed-off-by" line described in 
> the two documents I referenced.  The "signed-off-by" line makes the 
> lawyers happy.
> 
> Since you missed that major legal item, please _read_ the following 
> documents:
> 
> http://linux.yyz.us/patch-format.html (see #5, "Sign your work")
> http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt

Hi,

Maybe you already have this planned or patched, but it wasn't
in the "cosmetic" patch file.

In s2io.c, please convert this struct to C99 syntax:
static struct pci_driver s2io_driver = {
       name:"S2IO",
       id_table:s2io_tbl,
       probe:s2io_init_nic,
       remove:__devexit_p(s2io_rem_nic),
};

so that sparse won't complain like so:
drivers/net/s2io.c:238:7: warning: obsolete struct initializer, use 
C99 syntax
drivers/net/s2io.c:239:7: warning: obsolete struct initializer, use 
C99 syntax
drivers/net/s2io.c:240:7: warning: obsolete struct initializer, use 
C99 syntax
drivers/net/s2io.c:241:7: warning: obsolete struct initializer, use 
C99 syntax

and if you haven't tried sparse on the driver, that would be a
good idea.


-- 
~Randy
