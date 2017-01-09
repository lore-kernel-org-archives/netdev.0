From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: patch 4.8 "net: handle no dst on skb in icmp6_send"
Date: Mon, 9 Jan 2017 08:58:47 +0100
Message-ID: <20170109075847.GA11978@kroah.com>
References: <02a7e2d2-cc1d-1c64-ac9b-7daf8a834b56@spamcop.net>
 <20170108.175008.1125416899482175990.davem@davemloft.net>
 <520a2f27-9198-f40e-3c17-06a37d497c9c@spamcop.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        dsa@cumulusnetworks.com, stable@vger.kernel.org
To: Bronek Kozicki <brok@spamcop.net>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <520a2f27-9198-f40e-3c17-06a37d497c9c@spamcop.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 09, 2017 at 07:53:49AM +0000, Bronek Kozicki wrote:
> On 08/01/2017 22:50, David Miller wrote:
> > From: Bronek Kozicki <brok@spamcop.net>
> > Date: Sun, 8 Jan 2017 21:46:18 +0000
> > 
> > > Hello,
> > > 
> > > any particular reason why this fix
> > > https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=79dc7e3f1cd323be4c81aa1a94faa1b3ed987fb2
> > > was missed from stable 4.8 line? Apparently the bug being fixed has
> > > its own https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-9919
> > > 
> > > Thank you for your hard work and best regards
> > 
> > You should always check the networking -stable queue before asking
> > such questions:
> > 
> > 	http://patchwork.ozlabs.org/bundle/davem/stable/?submitter=&state=*&q=&archive=
> > 
> > Every patch sitting there is queued up and will be submitted to -stable
> > at some time in the next week or two, or whenever I get around to vetting
> > and submitting -stable changes.
> > 
> > The patch you are asking about it in fact in there, and will be attended
> > to at an appropriate time.
> 
> 
> Thank you David for prompt reply. I guess perhaps you are not aware that
> patches to stable line 4.8 might not be accepted after Sun Jan 8th
> (yesterday), and it will be considered EOL by version 4.8.17 ?

It's ok, no one should be using 4.8 anymore now, and if this is fixed in
4.9, all is good :)

thanks,

greg k-h
