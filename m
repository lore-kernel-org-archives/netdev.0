From: Jes Sorensen <jes@wildopensource.com>
Subject: Re: FW: Submission for S2io 10GbE driver
Date: 05 Feb 2004 18:23:50 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <yq03c9pkt4p.fsf@wildopensource.com>
References: <40220D15.60603@pobox.com>
	<000001c3ec34$af53b8e0$5d50ff11@S2IOtech.com>
	<20040205223413.GB2508@cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Leonid Grossman <leonid.grossman@s2io.com>,
        "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Anton Blanchard'" <anton@samba.org>, "'Andi Kleen'" <ak@suse.de>,
        netdev@oss.sgi.com, raghava.vatsavayi@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Grant Grundler <iod00d@hp.com>
In-Reply-To: <20040205223413.GB2508@cup.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Grant" == Grant Grundler <iod00d@hp.com> writes:

Grant> On Thu, Feb 05, 2004 at 02:09:09PM -0800, Leonid Grossman
Grant> wrote:
>> So, our ASIC is designed in a way that for a big endian machine the
>> swapper control need not be touched, and for little endian box both
>> register and DMA accesses have to be configured to swap - it would
>> be nice to have the same configuration working on all systems, but
>> this did not seem possible.

Grant> It's probably not. It sounds like the Tigon2 driver (acenic)
Grant> which has similar HW support. You see how endianess is handled
Grant> there.

Grant,

I have a feeling Leonid is fairly familiar with the acenic design ;-)

But yes it's very similar, I made the same mistake originally in the
acenic driver trying to set different swap modes for little vs big
endian.

Cheers,
Jes
