From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH 3/3] ath10k: add firmware files
Date: Sun, 16 Mar 2014 13:17:52 -0700
Message-ID: <CAB=NE6UP7dAwBHWUvtqAWksbrrdJ=vBRmT2PfcJPdeNhHfb7Kw@mail.gmail.com>
References: <20140314084501.23100.13103.stgit@x230> <20140314084514.23100.72654.stgit@x230>
 <CAB=NE6WW8yX4kdy02j2fT4g0JvYj4a_XkiqYtXKZSMB7FHuwNg@mail.gmail.com> <1394996230.15764.113.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	ath10k@lists.infradead.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394996230.15764.113.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 16, 2014 at 11:57 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Fri, 2014-03-14 at 05:36 -0700, Luis R. Rodriguez wrote:
>> On Fri, Mar 14, 2014 at 1:45 AM, Kalle Valo <kvalo@qca.qualcomm.com> wrote:
> [...]
>> > + NO LICENSES OR OTHER RIGHTS,
>> > +WHETHER EXPRESS, IMPLIED, BASED ON ESTOPPEL OR OTHERWISE, ARE GRANTED
>> > +TO ANY PARTY'S PATENTS, PATENT APPLICATIONS, OR PATENTABLE INVENTIONS
>> > +BY VIRTUE OF THIS LICENSE OR THE DELIVERY OR PROVISION BY QUALCOMM
>> > +ATHEROS, INC. OF THE SOFTWARE.
>>
>> This -- however is new to linux-firmware -- and I hereby raise a big
>> red fucking flag. All other licenses on linux-firmware provide at the
>> very least a limited patent grant. What makes Qualcomm special ?
> [...]
>
> There are several licence texts that don't mention patents at all.  I'm
> assuming that the companies submitting firmware for inclusion in Linux
> or linux-firmware do intend to grant whatever licences are required to
> distribute it to end users.

Agreed, this would be the only fair thing.

> Several licence texts explicitly exclude patent licences relating to any
> *other* products of the same company, but that's quite redundant.

Sure.

> However this language seems to explicitly exclude *any* patent licence.

Yeap, they are making it crystal clear.

> You're right to raise a red flag because, assuming Qualcomm does have
> patents that cover the firmware alone, this seems to disallow
> redistribution in whatever jurisdictions those patents apply.

I'm also fearful of this setting a precedent for other vendors. I'll
highlight, as it was discussed in our last Linux wireless summit, with
the way things are going forward for all companies with 802.11 doing
Single Chip designs combining more and more technologies together
(first it was Bluetooth) and moving move towards a big fat firmware
model (worst case Ethernet like 802.11 drivers) the blending will push
a fine line even further as technologies used to the archaic patent
licensing model get combined with technologies that were free of this
crazy ludicrous archaic business model practice. Apart from firmware
architecture in consideration for the technology combinations this
also has implications for open firmware. The division of where
companies are willing to push out open firmware is on the line here.
I'm not only concerned with the removal of open firmware as an option
but also seriously concerned over the quality and *security* of such
firmware, just as I've always been with the quality and security of
proprietary drivers. In the good 'ol Atheros days were able to
innovate with the community on open firmware first with ar9170 which
lead to carl9170.fw, that proved as great proof of concept to open
firmware further up, even with the support of Tensilca on ath9k_htc,
albeit under the Clear BSD License which also explicitly removes any
patent grants. The upstream linux-firmware for ath9k_htc however is
under the old Atheros firmware license which does provide a limited
patent grant. The line was drawn on ath10k...

To avoid patches as this one should we define some basic guidelines
for linux-firmware acceptable licenses?

> Ben.
>
> --
> Ben Hutchings
> Computers are not intelligent.  They only think they are.

For now.

  Luis
