From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: ethtool -d no longer works for e1000
Date: Wed, 9 Mar 2005 18:54:34 -0600
Message-ID: <200503091854.34466.jdmason@us.ibm.com>
References: <76FA8CF8F1F53240BB5B962A3385A5800256F787@orsmsx405>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Ben Greear" <greearb@candelatech.com>,
        "Ganesh Venkatesan" <ganesh.venkatesan@gmail.com>, netdev@oss.sgi.com
To: "cramerj" <cramerj@intel.com>
In-Reply-To: <76FA8CF8F1F53240BB5B962A3385A5800256F787@orsmsx405>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 09 March 2005 06:35 pm, cramerj wrote:
> Ah!  Yes, if you're running ethtool 1.8, then this was an issue (or
> rather, an annoyance) in e1000.c where we would default to mac_type =
> e1000_undefined for any newer hardware.  Continuous updates to this file
> for every piece of hardware we released got old pretty quick.  We've
> since changed the default mac_type to e1000_82543, which has a basic set
> of registers that haven't changed with each hardware release.  And
> although the e1000_82546 mac_type exists, it isn't yet being assigned to
> the 82546GB hardware (again, see e1000.c), thus the error.
>
> Long story short, an updated ethtool should do the trick.
>
> Thanks,
> -Jeb

Ah, I am running ethtool 3 on a 82545 chip, that is probably why mine works.

Thanks,
Jon
