From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Thu, 26 May 2005 17:28:55 -0700
Message-ID: <468F3FDA28AA87429AD807992E22D07E056F70D4@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Andrew Morton" <akpm@osdl.org>, "Jian Jun He" <hejianj@cn.ibm.com>,
        <anton@samba.org>, <rende@cn.ibm.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, <jgarzik@pobox.com>,
        <wangjs@cn.ibm.com>, "Ronciak, John" <john.ronciak@intel.com>,
        <cdlwangl@cn.ibm.com>, <linuxppc64-dev@lists.linuxppc.org.sgi.com>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Herbert Xu" <herbert@gondor.apana.org.au>,
        "Ganesh Venkatesan" <ganesh.venkatesan@gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Would adding flush_sheduled_tasks() to e100_down, do it?

Ganesh.

>-----Original Message-----
>From: Herbert Xu [mailto:herbert@gondor.apana.org.au]
>Sent: Thursday, May 26, 2005 5:21 PM
>To: Ganesh Venkatesan
>Cc: Venkatesan, Ganesh; Andrew Morton; Jian Jun He; anton@samba.org;
>rende@cn.ibm.com; Brandeburg, Jesse; jgarzik@pobox.com;
wangjs@cn.ibm.com;
>Ronciak, John; cdlwangl@cn.ibm.com; linuxppc64-
>dev@lists.linuxppc.org.sgi.com; netdev@oss.sgi.com
>Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while
running
>rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
>
>On Fri, May 27, 2005 at 10:11:23AM +1000, herbert wrote:
>>
>> Sorry, I was not aware that you've already added the sched work
>> in the driver.  With that it should work correctly.
>
>BTW, I was just checking out your sched work code.  There needs
>to be synchronisation between the tx_timeout task and the stop
>method.  Otherwise they can race against each other or worse
>tx_timeout could keep running even after stop has finished.
>
>Cheers,
>--
>Visit Openswan at http://www.openswan.org/
>Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
>Home Page: http://gondor.apana.org.au/~herbert/
>PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
