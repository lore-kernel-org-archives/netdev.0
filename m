From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 4/6] test_bpf: add module parameters to filter the tests
 to run.
Date: Mon, 03 Aug 2015 18:34:42 +0200
Message-ID: <55BF9822.3070000@iogearbox.net>
References: <1438610528-14245-1-git-send-email-nschichan@freebox.fr> <1438610528-14245-5-git-send-email-nschichan@freebox.fr> <55BF8F90.5030001@iogearbox.net> <55BF9590.4080205@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Nicolas Schichan <nschichan@freebox.fr>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55BF9590.4080205@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/03/2015 06:23 PM, Nicolas Schichan wrote:
...
>> Btw, for the range test in prepare_bpf_tests(), you could also reject
>> a negative lower bound index right there.
>
> I thought it was better to have all the sanity checks grouped in
> prepare_bpf_tests() (with the checking of the test_name and test_id parameters
> nearby) ? Also a negative lower bound is meaning that no range has been set so
> all tests should be run.

I just got a bit confused when loading test_range=-100,1 was not rejected, but
they do indeed all run in this case.

Thanks,
Daniel
