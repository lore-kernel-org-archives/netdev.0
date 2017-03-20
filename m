From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v5 3/3] A Sample of using socket cookie and uid
 for traffic monitoring
Date: Tue, 21 Mar 2017 00:07:52 +0100
Message-ID: <58D060C8.7010507@iogearbox.net>
References: <1490035266-9861-1-git-send-email-chenbofeng.kernel@gmail.com> <1490035266-9861-4-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>, netdev@vger.kernel.org,
        Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36242 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932072AbdCTXHz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 19:07:55 -0400
In-Reply-To: <1490035266-9861-4-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2017 07:41 PM, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
>
> Add a sample program to demostrate the possible usage of
> get_socket_cookie and get_socket_uid helper function. The program will
> store bytes and packets counting of in/out traffic monitored by iptables
> and store the stats in a bpf map in per socket base. The owner uid of
> the socket will be stored as part of the data entry. A shell script for
> running the program is also included.
>
> Signed-off-by: Chenbo Feng <fengc@google.com>
[...]
> +int main(int argc, char *argv[])
> +{
> +	if (argc > 2) {
> +		printf("Too many argument provided\n");
> +		return 1;
[...]
> +
> +	return 0;
> +}
> +
> +
> +
> +
> +
> +

Did these bits slip in accidentally?

> diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
> index 3705fba..8ab36a0 100644
> --- a/samples/bpf/libbpf.h
> +++ b/samples/bpf/libbpf.h
> @@ -135,6 +135,16 @@ struct bpf_insn;
>   		.off   = OFF,					\
>   		.imm   = 0 })
>
[...]
