From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [BUG] New Kernel Bugs
Date: Wed, 14 Nov 2007 15:30:40 +0100
Message-ID: <20071114143040.GA31025@elte.hu>
References: <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <20071113164650.GA28493@elte.hu> <4739E3D0.10201@rtr.ca> <20071113183925.GF17785@parisc-linux.org> <4739F069.6050102@rtr.ca> <20071113184902.GG17785@parisc-linux.org> <4739F2DD.5050802@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <matthew@wil.cx>, alsa-devel@alsa-project.org,
	netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	linux-kernel@vger.kernel.org, protasnb@gmail.com,
	linux-ide@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Mark Lord <liml@rtr.ca>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
Content-Disposition: inline
In-Reply-To: <4739F2DD.5050802@rtr.ca>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org


* Mark Lord <liml@rtr.ca> wrote:

>> You're assuming that everything in linux-2.6 was downloaded; that's 
>> not true.  Everything in linux-2.6/.git was downloaded; but then you 
>> do a checkout which happens to approximately double the size of the 
>> linux-2.6 directory.
> ..
>
> Ah, I wondered why it took only half an hour to download.

and you can get even lower than the 260MB by downloading a shallow clone 
of v2.6.23 and then populating the git tree from tht point on. (see the 
--depth parameter of git-clone) [because most of the time you want to 
bisect back to the last stable release, not back to 2 years of git 
history.]

	Ingo
