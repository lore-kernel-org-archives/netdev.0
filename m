From: maximilian attems <janitor@sternwelten.at>
Subject: Re: [patch 2.4] back port msleep(), msleep_interruptible()
Date: Sun, 31 Oct 2004 15:43:53 +0100
Message-ID: <20041031144353.GA28667__34228.8444554017$1099234073$gmane$org@stro.at>
References: <20040923221303.GB13244@us.ibm.com> <20040923221303.GB13244@us.ibm.com> <5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de> <415CD9D9.2000607@pobox.com> <20041030222228.GB1456@stro.at> <41841886.2080609@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Margit Schubert-While <margitsw@t-online.de>,
        Nishanth Aravamudan <nacc@us.ibm.com>, hvr@gnu.org,
        mcgrof@studorgs.rutgers.edu, kernel-janitors@lists.osdl.org,
        netdev@oss.sgi.com, Domen Puncer <domen@coderock.org>,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41841886.2080609@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Oct 2004, Jeff Garzik wrote:

> I'm pretty sure more than one of these symbols clashes with a symbol 
> defined locally in a driver.  I like the patch but we can't apply it 
> until the impact on existing code is evaluated.
> 
> 	Jeff

current 2.4 has no ssleep() nor jiffies_to_usecs() nor jiffies_to_msecs()
users. so no namespace conflicts on them.

i found a strange unsupported "msleep" syscall in
./arch/parisc/hpux/sys_hpux.c

left this one appart, i resend the msleep patch + 5 cleanup patches.
they remove duplicate msleep() or msecs_to_jiffies() definitions.
they are all compile tested, but the one touching drivers/char/shwdt.c
please show me if i forgot something.

--
maks
kernel janitor  	http://janitor.kernelnewbies.org/


ps dropped  prism54-devel@prism54.org from cc as this ml rejects my mails.
