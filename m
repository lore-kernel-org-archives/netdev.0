From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Ethernet MAC address question
Date: Tue, 15 Jun 2004 12:11:18 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40CF1FA6.3020701@pobox.com>
References: <200406151538.i5FFcJ720553@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Brown <broonie@sirena.org.uk>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <200406151538.i5FFcJ720553@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> So how does the driver distinguish between a valid, but incorrect MAC
> address, and the 'correct' MAC address?  The incorrect one that is the
> value that just happened to be in the uninitialized volatile registers,
> and the correct address which some magic platform means loaded into the
> same, but this time initialized, volatile registers.


You have to notice that certain platform-specific attributes are 
present, that tells your code to search in <this magic place> rather 
than the standard place for MAC address.

For example, some Compaqs have a magic MAC address location (this might 
even be pcnet32), and one solution proposed was looking for the 
platform's DMI table identifiers.  Another solution -- working -- was to 
load the MAC address registers when the driver loads, and just hope it 
is a correct address.

	Jeff
