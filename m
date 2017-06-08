From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [RFC PATCH net-next 5/5] selftests/bpf: change
 test_verifier expectations
Date: Thu, 8 Jun 2017 16:27:47 +0100
Message-ID: <8033b93c-2d13-ad57-2a59-9fbb603a6e9c@solarflare.com>
References: <92db9689-af6a-e172-ba57-195e588f9cc0@solarflare.com>
	<b04aa1a3-2b6c-2d3d-f26f-17eaaa549539@solarflare.com>
	<20170608024334.jgo63s2fnoi5wmia@ast-mbp>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20170608024334.jgo63s2fnoi5wmia@ast-mbp>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/06/17 03:43, Alexei Starovoitov wrote:
> On Wed, Jun 07, 2017 at 04:00:02PM +0100, Edward Cree wrote:
>> Some of the verifier's error messages have changed, and some constructs
>>  that previously couldn't be verified are now accepted.
>>
>> Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
>> ---
>>  tools/testing/selftests/bpf/test_verifier.c | 226 ++++++++++++++--------------
>>  1 file changed, 116 insertions(+), 110 deletions(-)
> imo this rewrite needs more than one additional test.
> Like i counted at least 2 new verifier features (like negative and ptr & 0x40)
> All the new logic needs to be covered by tests.
Yes, I will write some new tests to cover the new features.  I just wanted
 to get some comments on the patch first, in case I was barking up entirely
 the wrong tree.

-Ed
