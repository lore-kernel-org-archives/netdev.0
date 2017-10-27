From: David Ranch <linux-hams@trinnet.net>
Subject: Re: [PATCH v3 0/2] refactor code and mark expected switch
 fall-throughs
Date: Fri, 27 Oct 2017 07:47:10 -0700
Message-ID: <b0e6de21-b258-dc78-4710-a61b81ec419c@trinnet.net>
References: <cover.1509080630.git.garsilva@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Ralf Baechle <ralf@linux-mips.org>,
        walter harms <wharms@bfs.de>, Kevin Dawson <hal@kd.net.au>,
        "Bernard, f6bvp" <f6bvp@free.fr>,
        Thomas Osterried <thomas@osterried.de>
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        linux-hams@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <cover.1509080630.git.garsilva@embeddedor.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello Gustavo,

I appreciate you working on keeping up the kernel and maintaining some 
of the older feature areas like AX.25, Netrom, etc.  Other than auditing 
your code changes, can you tell me what you're changing? I've been 
attempting to find who / where does regression tests for the Linus 
kernel to potentially ADD test suites for this area.  In the recent 
past, we have seen a lot of toxicity creep into the kernel because no 
one is testing their changes and backing out this toxic code out of 
released Linux distributions takes a VERY long time.

I'm willing to try and help here but I really would like to follow some 
team's guidelines of how they would like tests to be created, supported, 
etc.  Be it in VMs, containers, specific automation languages, etc.

--David
KI6ZHD




On 10/26/2017 10:50 PM, Gustavo A. R. Silva wrote:
> The aim of this patchset is firstly to refactor code in nr_route.c in order to make it
> easier to read and maintain and, secondly, to mark some expected switch fall-throughs
> in preparation to enabling -Wimplicit-fallthrough.
>
> I have to mention that I did not implement any unit test.
> If someone has any suggestions on how I could test this piece of code
> it'd be greatly appreciated.
>
> Thanks
>
> Changes in v2:
>   - Make use of the swap macro and remove inline keyword as suggested by
>     Walter Harms and Kevin Dawson.
>
> Changes in v3:
>   - Update subject for both patches.
>   - Add this cover letter as suggested by David Miller.
>
> Gustavo A. R. Silva (2):
>    net: netrom: nr_route: refactor code in nr_add_node
>    net: netrom: nr_route: mark expected switch fall-throughs
>
>   net/netrom/nr_route.c | 62 ++++++++++++++++-----------------------------------
>   1 file changed, 19 insertions(+), 43 deletions(-)
>

