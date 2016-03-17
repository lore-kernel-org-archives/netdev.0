From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH v2] ARC: axs10x - add Ethernet PHY description in .dts
Date: Thu, 17 Mar 2016 12:10:37 +0000
Message-ID: <1458216636.14496.19.camel@synopsys.com>
References: <1458207712-29435-1-git-send-email-abrodkin@synopsys.com>
	 <56EA8DCC.8070308@cogentembedded.com>
	 <1458214678.14496.15.camel@synopsys.com>
	 <C2D7FE5348E1B147BCA15975FBA23075F4E903EF@us01wembx1.internal.synopsys.com>
	 <56EA9C0D.1090000@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-7"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Vineet.Gupta1@synopsys.com" <Vineet.Gupta1@synopsys.com>,
	"linux-snps-arc@lists.infradead.org"
	<linux-snps-arc@lists.infradead.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"robh@kernel.org" <robh@kernel.org>,
	"preid@electromag.com.au" <preid@electromag.com.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <56EA9C0D.1090000@cogentembedded.com>
Content-Language: en-US
Content-ID: <8140073CF184634699EC2A744205A0B8@internal.synopsys.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Thu, 2016-03-17 at 14:59 +-0300, Sergei Shtylyov wrote:
+AD4- Hello.
+AD4- 
+AD4- On 3/17/2016 2:41 PM, Vineet Gupta wrote:
+AD4- 
+AD4- +AD4- 
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +AD4- Following commit broke DW GMAC functionality on AXS10x boards:
+AD4- +AD4- +AD4- +AD4- +AD4- http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id+AD0-e34d65696d2ef13dc32f2a162556c86c461e
+AD4- +AD4- +AD4- +AD4- +AD4- d763
+AD4- +AD4- +AD4- +AD4- +AKAAoACgAKAAoA-Note that scripts/checkpatch.pl now enforces certain format for citing
+AD4- +AD4- +AD4- +AD4- commits: commit +ADw-12-digit SHA1+AD4- (+ACIAPA-commit summary+AD4AIg-).
+AD4- +AD4- 
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- Frankly I haven't run that patch through checkpatch due to patch
+AD4- +AD4- +AD4- simplicity.
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- But I'll try to not do any assumptions from now on and will try to
+AD4- +AD4- +AD4- use checkpatch for each and every thing I send :)
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- Thanks for spotting all his+ACE-
+AD4- +AD4- +AD4- 
+AD4- +AKAAoACgAKA-Sorry for not reporting everything on the 1st review.
+AD4- 
+AD4- +AD4- 
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- -Alexey
+AD4- +AD4- Sergei, do you mind providing a Ack/Reviewed-by on the patch below
+AD4- +AKAAPg-
+AD4- 
+AD4- Reviewed-by: Sergei Shtylyov +ADw-sergei.shtylyov+AEA-cogentembedded.com+AD4-
+AD4- 
+AD4- +AKAAoACgAKA-The patch here is white space damaged however: tabs were converted to+AKA-
+AD4- spaces. :-(

Well, I'm not really sure why that substitution happened because my local patch
is indeed with tabs.

That's an output of checkpatch:
------------------------+AD4-8------------------------
./scripts/checkpatch.pl 0001-ARC-axs10x-add-Ethernet-PHY-description-in-.dts.patch+AKA-
+AFs-1+AF0AKwCgAKA-Done+AKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoA-gedit 0001-ARC-axs10x-add-Ethernet-PHY-description-in-.dts.patch
WARNING: Possible unwrapped commit description (prefer a maximum 75 chars per line)
+ACM-7:+AKA-
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id+AD0-e34d65696d2ef13dc32f2a162556c86c461ed763

ERROR: Please use git commit description style 'commit +ADw-12+- chars of sha1+AD4- (+ACIAPA-title line+AD4AIg-)' - ie: 'commit e34d65696d2e
(+ACI-stmmac: create of compatible mdio bus for stmmac driver+ACI-)'
+ACM-7:+AKA-
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id+AD0-e34d65696d2ef13dc32f2a162556c86c461ed763

total: 1 errors, 1 warnings, 14 lines checked

0001-ARC-axs10x-add-Ethernet-PHY-description-in-.dts.patch has style problems, please review.
------------------------+AD4-8------------------------

If there were spaces we would see tons of:
------------------------+AD4-8------------------------
ERROR: code indent should use tabs where possible
+ACM-43: FILE: arch/arc/boot/dts/axs10x+AF8-mb.dtsi:50:
+-+AKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACg-mdio0 +AHsAJA-
------------------------+AD4-8------------------------
which I didn't see.

-Alexey