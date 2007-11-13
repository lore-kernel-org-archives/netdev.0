From: Mark Lord <liml@rtr.ca>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 13:43:53 -0500
Message-ID: <4739F069.6050102@rtr.ca>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <20071113164650.GA28493@elte.hu> <4739E3D0.10201@rtr.ca> <20071113183925.GF17785@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, alsa-devel@alsa-project.org,
	netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	linux-kernel@vger.kernel.org, protasnb@gmail.com,
	linux-ide@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20071113183925.GF17785@parisc-linux.org>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> On Tue, Nov 13, 2007 at 12:50:08PM -0500, Mark Lord wrote:
>> It's a 540MByte download over a slow link for everyone else.
> 
> Where do you get this number from?
> $ du -sh .git/objects/pack/
> 249M    .git/objects/pack/
> $ du -sh .git/objects/
> 253M    .git/objects/
> 
> ie about half what you claim.
..

No, it's from earlier in this very thread:

Adrian Bunk wrote:
> The small instruction below is enough for everyone who is able to 
> build his own kernel to do a git bisect.
..
> <--  snip  -->
> 
> 
> # install git
> 
> # clone Linus' tree:
> git clone \ 
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
..

mkdir t
cd t
git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
(wait half an hour)
/usr/bin/du -s linux-2.6
522732  linux-2.6
