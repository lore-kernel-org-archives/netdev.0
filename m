From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] netfilter: logging copyrights is useless
Date: Wed, 15 Mar 2017 14:57:59 +0100
Message-ID: <20170315135759.nzszcnbgh2o4xytm@nataraja>
References: <20170315131739.16285-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, kadlec@blackhole.kfki.hu, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170315131739.16285-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Corentin,

On Wed, Mar 15, 2017 at 02:17:39PM +0100, Corentin Labbe wrote:
> Logging copyrights does not add any useful information in logs.
> This patch remove such logging

Historically, there were plenty of more copyright notices for certain
drivers or sections of the code being printed while booting.  I still
remember fondly the many ethernet driver notices of a Donald Becker, for
example.

I understand that it is questionable whether or not such statements are
"useful".  You might argue, their use is in
* stating a legal formality to the user
* making it simpler to determine if a given part of code is used in a
  given device (e.g. as part of GPL enforcement) while just logging the
  serial console and no requirement to (find a way to) dump the internal
  flash

Besides such practical arguments (it is of what use to whom), there are
legal concerns regarding the removal of copyright statements.  This
holds true on whether or not it is Free Software, or whether or not it
is GPL licensed.  If an author puts a copyright statement somehwere, he
exercises his right to be regarded as the author of the work.  It is
typically not permitted to remove such notices, as that would be a
copyright infringement in itself.

Also, beyond general legal concerns, the GPLv2 states explicitly:

> c) If the modified program normally reads commands interactively
> when run, you must cause it, when started running for such
> interactive use in the most ordinary way, to print or display an
> announcement including an appropriate copyright notice and a notice
> that there is no warranty (or else, saying that you provide a
> warranty) and that users may redistribute the program under these
> conditions, and telling the user how to view a copy of this License.
> (Exception: if the Program itself is interactive but does not normally
> print such an announcement, your work based on the Program is not
> required to print an announcement.)

Now you can argue whether the kernel is a an interactive program, but at
least you can see some intent to not remove any notices/messages that
were originally present in the program.

So I think your patch could only applied if the respective copyright
holders agree to remove their respective notices.

I personally would argue to keep them.  Nobody has complained about them
so far, and they have probably saved many weeks of my work time in GPL
compliance / enforcement work.  I understand this is a "niche use case",
though ;)

-- 
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
============================================================================
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie
