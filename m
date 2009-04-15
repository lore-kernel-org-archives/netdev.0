From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: fixed phy -- how do we decide to use this code?
Date: Wed, 15 Apr 2009 12:20:14 -0500
Message-ID: <19D58213-D01B-47C1-8A78-6C1D86E624AE@kernel.crashing.org>
References: <B660E2DF-5F6A-4939-9D20-3AB8E7C69EDB@kernel.crashing.org>
	<20090415161728.GA5670@oksana.dev.rtsoft.ru>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linuxppc-dev Development <linuxppc-dev@ozlabs.org>
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090415161728.GA5670@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Apr 15, 2009, at 11:17 AM, Anton Vorontsov wrote:

> On Wed, Apr 15, 2009 at 10:54:40AM -0500, Kumar Gala wrote:
>> Vitaly, Anton
>>
>> You guys have used this code.. I was wondering how we decide to  
>> used the
>> fixed phy vs another phy.  Is this a runtime decision based on  
>> something
>> in the device tree or purely at compile time?
>
> It's specified via fixed-link property in the device tree.
> The bindings described in Documentation/powerpc/dts-bindings/fsl/ 
> tsec.txt.

Ok, I want to make sure I can build a platform that uses a normal PHY  
that is detected (like a marvell PHY) and and have another platform  
that is fixed-link in the same kernel image.  Sounds like we'll be ok.

- k
