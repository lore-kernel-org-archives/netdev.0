From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 02 Jun 2005 17:18:12 -0700 (PDT)
Message-ID: <20050602.171812.48807872.davem@davemloft.net>
References: <468F3FDA28AA87429AD807992E22D07E0450BFDB@orsmsx408>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@us.ibm.com, shemminger@osdl.org, hadi@cyberus.ca,
        mitch.a.williams@intel.com, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: john.ronciak@intel.com
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E0450BFDB@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Ronciak, John" <john.ronciak@intel.com>
Date: Thu, 2 Jun 2005 17:11:20 -0700

> I like this idea as well but I do an issue with it.  How would this
> stack code find out that the weight is too high and pacekts are being
> dropped (not being polled fast enough)?  It would have to check the
> controller stats to see the error count increasing for some period.  I'm
> not sure this is workable unless we have some sort of feedback which the
> driver could send up (or set) saying that this is happening and the
> dynamic weight code could take into acount.

What more do you need other than checking the statistics counter?  The
drop statistics (the ones we care about) are incremented in real time
by the ->poll() code, so it's not like we have to trigger some
asynchronous event to get a current version of the number.
