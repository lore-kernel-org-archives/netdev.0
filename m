From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 17:49:39 +0100
Message-ID: <20071113164939.GA2552@elte.hu>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <40f323d00711130752k19cab8eauc3456721274b3267@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Lord <liml@rtr.ca>, Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Benoit Boissinot <bboissin@gmail.com>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
Content-Disposition: inline
In-Reply-To: <40f323d00711130752k19cab8eauc3456721274b3267@mail.gmail.com>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org


* Benoit Boissinot <bboissin@gmail.com> wrote:

> For debugging, maybe it's time someone does an amazon ec2+s3 service 
> to automate the bisecting and create .deb/.rpm from git, I don't know 
> how much it would cost though.

a few months ago i estimated the costs of this and it's just a few 
terabytes so within arm's reach. As long as the .deb/.rpm's are built by 
tracking -git in a rolling fashion CPU time should not be a big issue. 
The only limit is download bandwidth - but even that problem might be 
solvable via a huge git repository of ready-to-boot .o's that are linked 
together on the tester's machine.

	Ingo
