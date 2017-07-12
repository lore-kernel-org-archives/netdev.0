From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net] nfp: freeing the wrong variable
Date: Wed, 12 Jul 2017 00:54:41 -0700
Message-ID: <20170712005441.5f9169d0@cakuba.netronome.com>
References: <20170712074206.otviyjx2qhuz3snt@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>,
        "David S. Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170712074206.otviyjx2qhuz3snt@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Jul 2017 10:42:06 +0300, Dan Carpenter wrote:
> We accidentally free a NULL pointer and leak the pointer we want to
> free.  Also you can tell from the label name what was intended.  :)
> 
> Fixes: abfcdc1de9bf ("nfp: add a stats handler for flower offloads")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Thanks!
