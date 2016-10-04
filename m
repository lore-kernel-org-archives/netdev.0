From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v4 2/2] libxt_hashlimit: Create revision 2 of
 xt_hashlimit to support higher pps rates
Date: Tue, 4 Oct 2016 08:57:57 +0200
Message-ID: <20161004065757.GB13023@salvia>
References: <20160926190852.GB10252@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu, johunt@akamai.com,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, pai.vishwain@gmail.com
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160926190852.GB10252@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 26, 2016 at 03:08:52PM -0400, Vishwanath Pai wrote:
> libxt_hashlimit: Create revision 2 of xt_hashlimit to support higher pps
> rates
> 
> Create a new revision for the hashlimit iptables extension module. Rev 2
> will support higher pps of upto 1 million, Version 1 supports only 10k.
> 
> To support this we have to increase the size of the variables avg and
> burst in hashlimit_cfg to 64-bit. Create two new structs hashlimit_cfg2
> and xt_hashlimit_mtinfo2 and also create newer versions of all the
> functions for match, checkentry and destory.

Also applied, thanks.
