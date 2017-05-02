From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: IPsec PFP support on linux
Date: Tue, 2 May 2017 10:05:26 -0400
Message-ID: <20170502140526.GF5843@oracle.com>
References: <20170502123238.GE5843@oracle.com>
 <B4EE88ED-B403-42C3-A6D8-1A2526F1DA67@nohats.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, borisp@mellanox.com, swan@lists.libreswan.org,
 netdev@vger.kernel.org, ilant@mellanox.com, linux-crypto@vger.kernel.org,
 herbert@gondor.apana.org.au
To: Paul Wouters <paul@nohats.ca>
Return-path: <swan-bounces@lists.libreswan.org>
Content-Disposition: inline
In-Reply-To: <B4EE88ED-B403-42C3-A6D8-1A2526F1DA67@nohats.ca>
List-Unsubscribe: <https://lists.libreswan.org/mailman/options/swan>,
 <mailto:swan-request@lists.libreswan.org?subject=unsubscribe>
List-Archive: <https://lists.libreswan.org/pipermail/swan/>
List-Post: <mailto:swan@lists.libreswan.org>
List-Help: <mailto:swan-request@lists.libreswan.org?subject=help>
List-Subscribe: <https://lists.libreswan.org/mailman/listinfo/swan>,
 <mailto:swan-request@lists.libreswan.org?subject=subscribe>
Errors-To: swan-bounces@lists.libreswan.org
Sender: "Swan" <swan-bounces@lists.libreswan.org>
List-Id: netdev.vger.kernel.org

On (05/02/17 09:58), Paul Wouters wrote:
>    I think you want to use Opportunistic IPsec, eg see 
>    https://libreswan.org/wiki/HOWTO:_Opportunistic_IPsec

I dont think that what I want is opportunistic ipsec..

taking an extreme example, I can set up the ipsec tunnels with 
esp-null for *.5001 and 5001.* (and that's how I'm able to
trigger quick mode in my experiment).

But I want each 5-tuple to/from 5001 to get its own SPI. That
is not happening in my case. 

If I used OE, I would *never* get a per-5-tuple SPI, right?
(I can give this a try later today but the rfc definition of OE is
not what I have in mind- I really want PFP, not OE).

>    Note that IKEv2 also allows you to define one connection and instantiate
>     a connection based on the trigger packet whose src/dst proto/port are
>    included in the IKEv2 packet as traffic selectors. See RFC7296 and
>    "narrowing".

yes, the rfc's permit this, I'm not sure how to set up my 
SPD for this though.
